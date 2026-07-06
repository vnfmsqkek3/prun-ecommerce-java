import api from './api';

export const getProducts = async (page = 0, size = 20, category) => {
  const params = { page, size };
  if (category) params.category = category;
  const response = await api.get('/api/products', { params });
  return response.data;
};

export const getProductById = async (id) => {
  const response = await api.get(`/api/products/${id}`);
  return response.data;
};
