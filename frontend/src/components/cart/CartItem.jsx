import { formatPrice } from '../../utils/formatters';
import Button from '../common/Button';
import './CartItem.css';

function CartItem({ item, onQuantityChange, onRemove }) {
  return (
    <div className="cart-item">
      <div className="cart-item-info">
        <h3>{item.productName}</h3>
        <p className="cart-item-price">{formatPrice(item.price)}</p>
      </div>
      <div className="cart-item-actions">
        <div className="quantity-controls">
          <button onClick={() => onQuantityChange(item.id, item.quantity - 1)} disabled={item.quantity <= 1}>-</button>
          <span>{item.quantity}</span>
          <button onClick={() => onQuantityChange(item.id, item.quantity + 1)}>+</button>
        </div>
        <p className="cart-item-subtotal">{formatPrice(item.price * item.quantity)}</p>
        <Button variant="danger" size="small" onClick={() => onRemove(item.id)}>삭제</Button>
      </div>
    </div>
  );
}

export default CartItem;
