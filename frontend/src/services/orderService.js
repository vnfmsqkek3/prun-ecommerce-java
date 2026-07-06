import api from './api';

export const createOrder = async (orderData) => {
  const response = await api.post('/api/orders', orderData);
  return response.data;
};

export const createOrderFromCart = async () => {
  const response = await api.post('/api/orders/from-cart');
  return response.data;
};

export const getOrders = async (page = 0, size = 20, status) => {
  const userId = localStorage.getItem('userId');
  const params = { userId, page, size };
  if (status) params.status = status;
  const response = await api.get('/api/orders', { params });
  return response.data;
};

export const getOrderById = async (id) => {
  const response = await api.get(`/api/orders/${id}`);
  return response.data;
};

export const cancelOrder = async (id) => {
  const response = await api.post(`/api/orders/${id}/cancel`);
  return response.data;
};
