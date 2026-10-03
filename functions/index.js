const functions = require('firebase-functions');
const Razorpay = require('razorpay');

const razorpay = new Razorpay({
  key_id: functions.config().razorpay.key_id || process.env.RAZORPAY_KEY_ID,
  key_secret: functions.config().razorpay.key_secret || process.env.RAZORPAY_KEY_SECRET,
});

exports.createRazorpayOrder = functions.https.onCall(async (data, context) => {
  const { amount } = data;
  if (!amount || amount <= 0) {
    throw new functions.https.HttpsError('invalid-argument', 'Amount must be positive');
  }
  const options = {
    amount: Math.round(amount * 100),
    currency: 'INR',
    receipt: 'receipt_' + Date.now(),
    payment_capture: 1,
  };
  try {
    const order = await razorpay.orders.create(options);
    return { order_id: order.id, amount: order.amount, currency: order.currency };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

exports.verifyRazorpaySignature = functions.https.onCall(async (data, context) => {
  const { order_id, payment_id, signature } = data;
  if (!order_id || !payment_id || !signature) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing fields');
  }
  const crypto = require('crypto');
  const generatedSignature = crypto
    .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
    .update(`${order_id}|${payment_id}`)
    .digest('hex');
  if (generatedSignature === signature) {
    return { valid: true };
  }
  throw new functions.https.HttpsError('permission-denied', 'Invalid signature');
});

exports.processRazorpayRefund = functions.https.onCall(async (data, context) => {
  const { payment_id, amount } = data;
  if (!payment_id) {
    throw new functions.https.HttpsError('invalid-argument', 'Payment ID is required');
  }
  try {
    const refund = await razorpay.payments.refund(payment_id, {
      amount: amount ? Math.round(amount * 100) : undefined,
    });
    return { refund_id: refund.id, status: refund.status, amount: refund.amount };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

exports.getRazorpayPaymentDetails = functions.https.onCall(async (data, context) => {
  const { payment_id } = data;
  if (!payment_id) {
    throw new functions.https.HttpsError('invalid-argument', 'Payment ID is required');
  }
  try {
    const payment = await razorpay.payments.fetch(payment_id);
    return {
      id: payment.id,
      amount: payment.amount,
      currency: payment.currency,
      status: payment.status,
      method: payment.method,
      created_at: payment.created_at,
    };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});
