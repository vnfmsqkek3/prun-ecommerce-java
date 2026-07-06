import api from './api';

export const signup = async (userData) => {
  const response = await api.post('/api/users/signup', userData);
  return response.data;
};

export const login = async (email, password) => {
  const response = await api.post('/api/users/login', { email, password });
  return response.data;
};

export const getMe = async () => {
  const response = await api.get('/api/users/me');
  return response.data;
};

export const updateMe = async (userData) => {
  const response = await api.put('/api/users/me', userData);
  return response.data;
};

export const changePassword = async (currentPassword, newPassword) => {
  await api.put('/api/users/me/password', { currentPassword, newPassword });
};
