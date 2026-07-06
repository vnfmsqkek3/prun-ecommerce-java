import { createContext, useContext, useState, useEffect } from 'react';
import * as userService from '../services/userService';

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [userId, setUserId] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const storedUserId = localStorage.getItem('userId');
    if (storedUserId) {
      setUserId(storedUserId);
      userService.getMe()
        .then(userData => setUser(userData))
        .catch(() => {
          localStorage.removeItem('userId');
          setUserId(null);
        })
        .finally(() => setLoading(false));
    } else {
      setLoading(false);
    }
  }, []);

  const login = async (email, password) => {
    const response = await userService.login(email, password);
    setUserId(response.userId);
    setUser(response.user);
    localStorage.setItem('userId', response.userId);
  };

  const logout = () => {
    setUserId(null);
    setUser(null);
    localStorage.removeItem('userId');
  };

  const updateUser = (userData) => {
    setUser(userData);
  };

  const value = {
    user,
    userId,
    isAuthenticated: !!userId,
    loading,
    login,
    logout,
    updateUser
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  return useContext(AuthContext);
}
