import Navigation from './Navigation';
import './Layout.css';

function Layout({ children, user, onLogout }) {
  return (
    <div className="layout">
      <Navigation user={user} onLogout={onLogout} />
      <main className="main-content">
        {children}
      </main>
    </div>
  );
}

export default Layout;
