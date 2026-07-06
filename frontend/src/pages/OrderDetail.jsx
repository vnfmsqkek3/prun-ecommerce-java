import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getOrderById, cancelOrder } from '../services/orderService';
import OrderItem from '../components/order/OrderItem';
import Button from '../components/common/Button';
import Loading from '../components/common/Loading';
import Alert from '../components/common/Alert';
import { formatPrice, formatDate, getStatusText } from '../utils/formatters';
import './OrderDetail.css';

function OrderDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [message, setMessage] = useState(null);

  useEffect(() => {
    fetchOrder();
  }, [id]);

  const fetchOrder = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await getOrderById(id);
      setOrder(data);
    } catch (err) {
      setError('주문을 찾을 수 없습니다');
    } finally {
      setLoading(false);
    }
  };

  const handleCancelOrder = async () => {
    if (!confirm('주문을 취소하시겠습니까?')) return;
    try {
      await cancelOrder(id);
      setMessage('주문이 취소되었습니다');
      await fetchOrder();
    } catch (err) {
      setError(err.response?.data?.message || '주문 취소에 실패했습니다');
    }
  };

  if (loading) return <Loading />;
  if (error && !order) return <Alert type="error" message={error} />;
  if (!order) return <div>주문을 찾을 수 없습니다</div>;

  return (
    <div className="order-detail-container">
      {message && <Alert type="success" message={message} onClose={() => setMessage(null)} />}
      {error && <Alert type="error" message={error} onClose={() => setError(null)} />}
      
      <div className="order-detail-header">
        <h1>주문 상세</h1>
        <Button variant="secondary" onClick={() => navigate('/orders')}>목록으로</Button>
      </div>
      
      <div className="order-detail-card">
        <div className="order-detail-info">
          <div className="info-row">
            <span>주문 번호:</span>
            <span>#{order.id}</span>
          </div>
          <div className="info-row">
            <span>주문 날짜:</span>
            <span>{formatDate(order.createdAt)}</span>
          </div>
          <div className="info-row">
            <span>주문 상태:</span>
            <span className={`status-badge status-${order.status.toLowerCase()}`}>
              {getStatusText(order.status)}
            </span>
          </div>
        </div>
        
        <div className="order-items-section">
          <h2>주문 상품</h2>
          {order.items.map(item => (
            <OrderItem key={item.id} item={item} />
          ))}
        </div>
        
        <div className="order-total-section">
          <span>총 금액:</span>
          <span className="total-amount">{formatPrice(order.totalAmount)}</span>
        </div>
        
        {order.status === 'PENDING' && (
          <div className="order-actions">
            <Button variant="danger" onClick={handleCancelOrder}>주문 취소</Button>
          </div>
        )}
      </div>
    </div>
  );
}

export default OrderDetail;
