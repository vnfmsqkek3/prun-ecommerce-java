import { formatPrice } from '../../utils/formatters';
import './OrderItem.css';

function OrderItem({ item }) {
  return (
    <div className="order-item">
      <div className="order-item-info">
        <h4>{item.productName}</h4>
        <p>{formatPrice(item.price)} × {item.quantity}</p>
      </div>
      <p className="order-item-subtotal">{formatPrice(item.price * item.quantity)}</p>
    </div>
  );
}

export default OrderItem;
