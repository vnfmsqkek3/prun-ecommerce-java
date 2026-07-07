import axios from 'axios';

// 상대경로 → nginx(도커/prod) 또는 vite proxy(로컬 dev)가 백엔드/대기열로 라우팅
const api = axios.create({ baseURL: '' });

// 로그인 없는 데모 — 게스트 userId 를 localStorage 에 유지
export function userId() {
  let id = localStorage.getItem('userId');
  if (!id) {
    id = 'guest-' + Math.random().toString(36).slice(2, 10);
    localStorage.setItem('userId', id);
  }
  return id;
}

export default api;
