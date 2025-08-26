const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

// Helpers
function shortId(id) {
    return id ? id.substring(0, 8) : 'N/A';
}

function safeNumber(n, def = 0) {
    return typeof n === 'number' && !Number.isNaN(n) ? n : def;
}

function toRupees(n) {
    const v = safeNumber(n, 0);
    return Math.round(v).toString();
}

function toStringData(obj) {
    const src = obj || {};
    return Object.fromEntries(Object.entries(src).map(([k, v]) => [String(k), String(v ?? '')]));
}

async function queueNotification(doc) {
return db.collection('notifications_queue').add({
token: doc.token,
title: doc.title || '',
body: doc.body || '',
data: doc.data || {},
userId: doc.userId || '',
createdAt: admin.firestore.FieldValue.serverTimestamp(),
processed: false,
source: doc.source || 'unknown',
isAdminNotification: !!doc.isAdminNotification,
});
}

async function notifyAdminsBatch(payloadBuilder) {
const adminTokens = await db.collection('userTokens').where('isAdmin', '==', true).get();
if (adminTokens.empty) {
console.log('No admin tokens found');
return;
}
const batch = db.batch();
let count = 0;
adminTokens.forEach((doc) => {
const t = doc.data();
if (!t.token) return;
const data = payloadBuilder(t);
const ref = db.collection('notifications_queue').doc();
batch.set(ref, {
token: t.token,
title: data.title || '',
body: data.body || '',
data: data.data || {},
userId: t.userId || '',
createdAt: admin.firestore.FieldValue.serverTimestamp(),
processed: false,
source: data.source || 'admin_broadcast',
isAdminNotification: true,
});
count += 1;
});
if (count > 0) {
await batch.commit();
console.log('✅ Sent ${count} admin notifications');
}
}

// Worker: Process notification queue (send via FCM)
exports.processNotificationQueue = functions.firestore
.document('notifications_queue/{notificationId}')
.onCreate(async (snap, context) => {
const notification = snap.data();
if (!notification) {
console.log('No notification data found');
return null;
}
try {
const message = {
token: notification.token,
notification: {
title: notification.title || '',
body: notification.body || '',
},
data: {
...toStringData(notification.data),
click_action: 'FLUTTER_NOTIFICATION_CLICK',
},
android: {
notification: {
channelId: notification.data?.channelId || 'order_notifications',
priority: 'high',
sound: 'default',
color: '#FF6B35',
},
},
apns: {
payload: {
aps: { sound: 'default', badge: 1 },
},
},
};

  const response = await messaging.send(message);
  console.log('✅ Notification sent successfully:', response);

  await snap.ref.update({
    processed: true,
    processedAt: admin.firestore.FieldValue.serverTimestamp(),
    response,
    status: 'sent',
  });

} catch (error) {
  console.error('❌ Error sending notification:', error);
  await snap.ref.update({
    processed: true,
    processedAt: admin.firestore.FieldValue.serverTimestamp(),
    error: error.message || String(error),
    status: 'failed',
  });
}
return null;
});

// Order status change -> notify user; if cancelled -> also notify admins
exports.onOrderStatusChange = functions.firestore
.document('orders/{orderId}')
.onUpdate(async (change, context) => {
const before = change.before.data() || {};
const after = change.after.data() || {};
const orderId = context.params.orderId;

const prev = String(before.orderStatus || '').toLowerCase();
const curr = String(after.orderStatus || '').toLowerCase();
if (prev === curr) {
  console.log('Order status unchanged, skipping notification');
  return null;
}

console.log('Order ${orderId} status: ${prev} → ${curr}');

try {
  // Notify user
  if (after.userId) {
    const userDoc = await db.collection('users').doc(after.userId).get();
    const fcmToken = userDoc.exists ? (userDoc.data() || {}).fcmToken : null;

    if (fcmToken) {
      let notificationData = null;
      switch (curr) {
        case 'confirmed':
          notificationData = {
            title: '✅ Order Confirmed!',
            body: `Order #${shortId(orderId)} confirmed and being prepared.`,
            screen: 'order_details',
            type: 'order_confirmed',
          };
          break;
        case 'preparing':
          notificationData = {
            title: '👨 Order Being Prepared!',
            body: `Order #${shortId(orderId)} is being prepared with care.`,
            screen: 'order_details',
            type: 'order_preparing',
          };
          break;
        case 'out_for_delivery':
        case 'shipping':
        case 'dispatch':
          notificationData = {
            title: '🚛 Out for Delivery!',
            body: `Order #${shortId(orderId)} is on the way! ETA: 10-15 min.`,
            screen: 'order_details',
            type: 'out_for_delivery',
          };
          break;
        case 'delivered':
          notificationData = {
            title: '🎉 Order Delivered!',
            body: `Order #${shortId(orderId)} delivered successfully!`,
            screen: 'order_details',
            type: 'order_delivered',
          };
          break;
        case 'cancelled':
        case 'canceled':
          notificationData = {
            title: '❌ Order Cancelled',
            body: `Order #${shortId(orderId)} has been cancelled.`,
            screen: 'order_details',
            type: 'order_cancelled',
          };
          break;
        default:
          notificationData = null;
      }

      if (notificationData) {
        await queueNotification({
          token: fcmToken,
          title: notificationData.title,
          body: notificationData.body,
          data: {
            screen: notificationData.screen,
            type: notificationData.type,
            orderId,
            channelId: 'order_notifications',
          },
          userId: after.userId,
          source: 'order_status_change',
        });
        console.log('✅ User notification queued for order status change');
      }
    }
  }

  // If user cancelled the order -> notify all admins too
  if (curr === 'cancelled' || curr === 'canceled') {
    const total = toRupees(after.total);
    const customerName = after.name || 'Customer';
    await notifyAdminsBatch(() => ({
      title: '⚠️ Order Cancelled by User',
      body: `Order #${shortId(orderId)} by ${customerName} cancelled. Amount: ₹${total}`,
      data: {
        screen: 'admin_order_details',
        type: 'order_cancelled_admin',
        orderId,
        channelId: 'admin_notifications',
      },
      source: 'order_cancelled_admin',
    }));
    console.log('✅ Admin cancellation notifications queued');
  }
} catch (error) {
  console.error('❌ Error in order status change handler:', error);
}
return null;
});

// New order -> notify user + admins
exports.onNewOrder = functions.firestore
.document('orders/{orderId}')
.onCreate(async (snap, context) => {
const orderData = snap.data() || {};
const orderId = context.params.orderId;

console.log('New order created:', orderId);

try {
  // Notify user
  if (orderData.userId) {
    const userDoc = await db.collection('users').doc(orderData.userId).get();
    const userToken = userDoc.exists ? (userDoc.data() || {}).fcmToken : null;

    if (userToken && orderData.orderStatus === 'created') {
      await queueNotification({
        token: userToken,
        title: '🎉 Order Placed Successfully!',
        body: `Order #${shortId(orderId)} placed. Total: ₹${toRupees(orderData.total)}`,
        data: {
          orderId,
          screen: 'order_details',
          type: 'order_placed',
          channelId: 'order_notifications',
        },
        userId: orderData.userId,
        source: 'new_order_user',
      });
    }else{
        await queueNotification({
                token: userToken,
                title: '❌ Failed to place order..',
                body: `Payment Failed for Order #${shortId(orderId)} placed. Total: ₹${toRupees(orderData.total)}`,
                data: {
                  orderId,
                  screen: 'order_details',
                  type: 'order_placed',
                  channelId: 'order_notifications',
                },
                userId: orderData.userId,
                source: 'new_order_user',
              });
    }
  }

  // Notify admins
  const customerName = orderData.customerName || orderData.name || 'Customer';
  if(orderData.orderStatus == 'created'){
    await notifyAdminsBatch(() => ({
        title: '🆕 New Order Received!',
        body: `Order #${shortId(orderId)} from ${customerName}. Amount: ₹${toRupees(orderData.total)}`,
        data: {
          orderId,
          screen: 'admin_order_details',
          type: 'new_order_admin',
          channelId: 'admin_notifications',
        },
        source: 'new_order_admin',
      }));
  }else{
    await notifyAdminsBatch(() => ({
        title: 'New Order,❌ Payment Failed',
        body: `Payment failed for Order #${shortId(orderId)} from ${customerName}. Amount: ₹${toRupees(orderData.total)}`,
        data: {
          orderId,
          screen: 'admin_order_details',
          type: 'new_order_admin',
          channelId: 'admin_notifications',
        },
        source: 'new_order_admin',
      }));
  }


  console.log('✅ Admin notifications queued');
} catch (error) {
  console.error('❌ Error in new order handler:', error);
}
return null;
});

// Low stock alert -> notify all admins when crossing threshold from above to at/below
exports.onLowStockAlert = functions.firestore
.document('products/{productId}')
.onUpdate(async (change, context) => {
const before = change.before.data() || {};
const after = change.after.data() || {};
const productId = context.params.productId;

const prevQty = Number(before.stockQuantity ?? 0);
const currQty = Number(after.stockQuantity ?? 0);
const threshold = Number(after.lowStockQuantity ?? 10);

// Trigger only when crossing from > threshold to <= threshold
if (!(prevQty > threshold && currQty <= threshold)) {
  return null;
}

try {
  const name = after.name || 'Unknown Product';
  const isOOS = currQty === 0;

  const title = isOOS ? '❗ OUT OF STOCK' : '⚠️ Low Stock Alert';
  const body = isOOS
    ? `${name} is out of stock. Immediate restock required!`
    : `${name} is running low. Only ${currQty} units remaining.`;

  await notifyAdminsBatch(() => ({
    title,
    body,
    data: {
      productId,
      productName: name,
      currentStock: String(currQty),
      screen: 'low_stock_alerts',
      type: 'low_stock_alert',
      channelId: 'admin_notifications',
    },
    source: 'low_stock_alert',
  }));

  console.log('✅ Low stock alert queued for admins:', productId, currQty);
} catch (error) {
  console.error('❌ Error in low stock alert handler:', error);
}
return null;
});