import ProductCard from './ProductCard';
import Loading from '../common/Loading';
import './ProductList.css';

function ProductList({ products, loading, onProductClick }) {
  if (loading) return <Loading />;
  
  if (products.length === 0) {
    return <div className="empty-message">상품이 없습니다</div>;
  }

  return (
    <div className="product-list">
      {products.map(product => (
        <ProductCard key={product.id} product={product} onClick={onProductClick} />
      ))}
    </div>
  );
}

export default ProductList;
