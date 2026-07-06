import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { getOrders } from '../services/orderService';
import OrderCard from '../components/order/OrderCard';
import Loading from '../components/common/Loading';
import Alert from '../components/common/Alert';
import './OrderList.css';

const STATUS_FILTERS = [
  { value: '', label: '전체' },
  { value: 'PENDING', label: '대기중' },
  { value: 'CONFIRMED', label: '확인됨' },
  { value: 'CANCELLED', label: '취소됨' }
];

function OrderList() {
  const navigate = useNavigate();
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [status, setStatus] = useState('');
  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);

  useEffect(() => {
    fetchOrders();
  }, [status, page]);

  const fetchOrders = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await getOrders(page, 20, status || undefined);
      setOrders(data.content);
      setTotalPages(data.totalPages);
    } catch (err) {
      setError('주문 목록을 불러오는데 실패했습니다');
    } finally {
      setLoading(false);
    }
  };

  const handleStatusChange = (newStatus) => {
    setStatus(newStatus);
    setPage(0);
  };

  const handleOrderClick = (orderId) => {
    navigate(`/orders/${orderId}`);
  };

  if (loading) return <Loading />;

  return (
    <div className="order-list-container">
      <h1>주문 내역</h1>
      
      {error && <Alert type="error" message={error} onClose={() => setError(null)} />}
      
      <div className="status-filters">
        {STATUS_FILTERS.map(filter => (
          <button
            key={filter.value}
            className={`status-filter ${status === filter.value ? 'active' : ''}`}
            onClick={() => handleStatusChange(filter.value)}
          >
            {filter.label}
          </button>
        ))}
      </div>
      
      {orders.length === 0 ? (
        <div className="empty-message">주문 내역이 없습니다</div>
      ) : (
        <>
          <div className="order-list">
            {orders.map(order => (
              <OrderCard key={order.id} order={order} onClick={handleOrderClick} />
            ))}
          </div>
          
          {totalPages > 1 && (
            <div className="pagination">
              <button onClick={() => setPage(p => Math.max(0, p - 1))} disabled={page === 0}>
                이전
              </button>
              <span>{page + 1} / {totalPages}</span>
              <button onClick={() => setPage(p => Math.min(totalPages - 1, p + 1))} disabled={page >= totalPages - 1}>
                다음
              </button>
            </div>
          )}
        </>
      )}
    </div>
  );
}

export default OrderList;
