import { Link } from 'react-router-dom';
import './Navigation.css';

function Navigation({ user, onLogout }) {
  return (
    <nav className="navigation">
      <div className="nav-container">
        <Link to="/" className="nav-logo">E-Commerce</Link>
        <ul className="nav-menu">
          <li><Link to="/">홈</Link></li>
          <li><Link to="/products">상품</Link></li>
          {user && (
            <>
              <li><Link to="/cart">장바구니</Link></li>
              <li><Link to="/orders">주문내역</Link></li>
              <li><Link to="/profile">내 정보</Link></li>
            </>
          )}
        </ul>
        <div className="nav-auth">
          {user ? (
            <>
              <span className="nav-user">{user.name}님</span>
              <button onClick={onLogout} className="nav-logout">로그아웃</button>
            </>
          ) : (
            <>
              <Link to="/login" className="nav-link">로그인</Link>
              <Link to="/signup" className="nav-link">회원가입</Link>
            </>
          )}
        </div>
      </div>
    </nav>
  );
}

export default Navigation;
