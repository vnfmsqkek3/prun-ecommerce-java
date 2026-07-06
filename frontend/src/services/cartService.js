import api from './api';

export const getCart = async () => {
  const response = await api.get('/api/carts');
  return response.data;
};

export const addToCart = async (productId, quantity) => {
  const response = await api.post('/api/carts/items', { productId, quantity });
  return response.data;
};

export const updateCartItem = async (cartItemId, quantity) => {
  const response = await api.put(`/api/carts/items/${cartItemId}`, { quantity });
  return response.data;
};

export const removeCartItem = async (cartItemId) => {
  await api.delete(`/api/carts/items/${cartItemId}`);
};

export const clearCart = async () => {
  await api.delete('/api/carts');
};
