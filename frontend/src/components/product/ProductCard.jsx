import { formatPrice, getCategoryText } from '../../utils/formatters';
import './ProductCard.css';

function ProductCard({ product, onClick }) {
  return (
    <div className="product-card" onClick={() => onClick(product.id)}>
      {product.imageUrl && (
        <img src={product.imageUrl} alt={product.name} className="product-image" />
      )}
      <div className="product-info">
        <span className="product-category">{getCategoryText(product.category)}</span>
        <h3 className="product-name">{product.name}</h3>
        <p className="product-price">{formatPrice(product.price)}</p>
        <p className="product-stock">재고: {product.stockQuantity}개</p>
      </div>
    </div>
  );
}

export default ProductCard;
