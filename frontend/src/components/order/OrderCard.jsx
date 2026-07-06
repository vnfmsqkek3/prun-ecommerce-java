import { formatPrice, formatDate, getStatusText } from '../../utils/formatters';
import './OrderCard.css';

function OrderCard({ order, onClick }) {
  return (
    <div className="order-card" onClick={() => onClick(order.id)}>
      <div className="order-header">
        <span className="order-id">주문 #{order.id}</span>
        <span className={`order-status status-${order.status.toLowerCase()}`}>
          {getStatusText(order.status)}
        </span>
      </div>
      <div className="order-info">
        <p>주문일: {formatDate(order.createdAt)}</p>
        <p>상품 {order.items.length}개</p>
        <p className="order-total">{formatPrice(order.totalAmount)}</p>
      </div>
    </div>
  );
}

export default OrderCard;
