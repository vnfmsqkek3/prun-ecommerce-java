import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { getCart, updateCartItem, removeCartItem, clearCart } from '../services/cartService';
import { createOrderFromCart } from '../services/orderService';
import CartItem from '../components/cart/CartItem';
import Button from '../components/common/Button';
import Loading from '../components/common/Loading';
import Alert from '../components/common/Alert';
import { formatPrice } from '../utils/formatters';
import './Cart.css';

function Cart() {
  const navigate = useNavigate();
  const [cart, setCart] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [message, setMessage] = useState(null);

  useEffect(() => {
    fetchCart();
  }, []);

  const fetchCart = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await getCart();
      setCart(data);
    } catch (err) {
      setError('장바구니를 불러오는데 실패했습니다');
    } finally {
      setLoading(false);
    }
  };

  const handleQuantityChange = async (cartItemId, newQuantity) => {
    if (newQuantity < 1) return;
    try {
      await updateCartItem(cartItemId, newQuantity);
      await fetchCart();
    } catch (err) {
      setError(err.response?.data?.message || '수량 변경에 실패했습니다');
    }
  };

  const handleRemove = async (cartItemId) => {
    try {
      await removeCartItem(cartItemId);
      await fetchCart();
      setMessage('상품이 삭제되었습니다');
    } catch (err) {
      setError('삭제에 실패했습니다');
    }
  };

  const handleClearCart = async () => {
    if (!confirm('장바구니를 비우시겠습니까?')) return;
    try {
      await clearCart();
      await fetchCart();
      setMessage('장바구니가 비워졌습니다');
    } catch (err) {
      setError('장바구니 비우기에 실패했습니다');
    }
  };

  const handleOrder = async () => {
    try {
      const order = await createOrderFromCart();
      setMessage('주문이 완료되었습니다');
      setTimeout(() => navigate(`/orders/${order.id}`), 1500);
    } catch (err) {
      setError(err.response?.data?.message || '주문에 실패했습니다');
    }
  };

  if (loading) return <Loading />;

  const totalAmount = cart?.items?.reduce((sum, item) => sum + item.price * item.quantity, 0) || 0;

  return (
    <div className="cart-container">
      <h1>장바구니</h1>
      
      {message && <Alert type="success" message={message} onClose={() => setMessage(null)} />}
      {error && <Alert type="error" message={error} onClose={() => setError(null)} />}
      
      {!cart?.items || cart.items.length === 0 ? (
        <div className="empty-cart">
          <p>장바구니가 비어있습니다</p>
          <Button onClick={() => navigate('/')}>쇼핑 계속하기</Button>
        </div>
      ) : (
        <>
          <div className="cart-items">
            {cart.items.map(item => (
              <CartItem
                key={item.id}
                item={item}
                onQuantityChange={handleQuantityChange}
                onRemove={handleRemove}
              />
            ))}
          </div>
          
          <div className="cart-summary">
            <div className="cart-total">
              <span>총 금액:</span>
              <span className="total-amount">{formatPrice(totalAmount)}</span>
            </div>
            <div className="cart-actions">
              <Button variant="secondary" onClick={handleClearCart}>전체 삭제</Button>
              <Button onClick={handleOrder}>주문하기</Button>
            </div>
          </div>
        </>
      )}
    </div>
  );
}

export default Cart;
