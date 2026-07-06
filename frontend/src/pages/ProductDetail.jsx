import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getProductById } from '../services/productService';
import { addToCart } from '../services/cartService';
import { useAuth } from '../context/AuthContext';
import Button from '../components/common/Button';
import Loading from '../components/common/Loading';
import Alert from '../components/common/Alert';
import { formatPrice, getCategoryText } from '../utils/formatters';
import './ProductDetail.css';

function ProductDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();
  const [product, setProduct] = useState(null);
  const [quantity, setQuantity] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [message, setMessage] = useState(null);

  useEffect(() => {
    fetchProduct();
  }, [id]);

  const fetchProduct = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await getProductById(id);
      setProduct(data);
    } catch (err) {
      setError('상품을 찾을 수 없습니다');
    } finally {
      setLoading(false);
    }
  };

  const handleAddToCart = async () => {
    if (!isAuthenticated) {
      navigate('/login', { state: { from: { pathname: `/products/${id}` } } });
      return;
    }

    try {
      await addToCart(product.id, quantity);
      setMessage('장바구니에 추가되었습니다');
    } catch (err) {
      setError(err.response?.data?.message || '장바구니 추가에 실패했습니다');
    }
  };

  if (loading) return <Loading />;
  if (error && !product) return <Alert type="error" message={error} />;
  if (!product) return <div>상품을 찾을 수 없습니다</div>;

  return (
    <div className="product-detail-container">
      {message && <Alert type="success" message={message} onClose={() => setMessage(null)} />}
      {error && <Alert type="error" message={error} onClose={() => setError(null)} />}
      
      <div className="product-detail">
        {product.imageUrl && (
          <img src={product.imageUrl} alt={product.name} className="product-detail-image" />
        )}
        
        <div className="product-detail-info">
          <span className="product-detail-category">{getCategoryText(product.category)}</span>
          <h1>{product.name}</h1>
          <p className="product-detail-price">{formatPrice(product.price)}</p>
          <p className="product-detail-description">{product.description}</p>
          <p className="product-detail-stock">재고: {product.stockQuantity}개</p>
          
          <div className="quantity-selector">
            <label>수량:</label>
            <input
              type="number"
              min="1"
              max={product.stockQuantity}
              value={quantity}
              onChange={(e) => setQuantity(Math.max(1, Math.min(product.stockQuantity, parseInt(e.target.value) || 1)))}
            />
          </div>
          
          <div className="product-actions">
            <Button onClick={handleAddToCart} disabled={product.stockQuantity === 0}>
              장바구니 담기
            </Button>
            <Button variant="secondary" onClick={() => navigate('/')}>
              목록으로
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}

export default ProductDetail;
