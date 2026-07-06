import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { getProducts } from '../services/productService';
import ProductList from '../components/product/ProductList';
import Alert from '../components/common/Alert';
import './Home.css';

const CATEGORIES = [
  { value: '', label: '전체' },
  { value: 'ELECTRONICS', label: '전자제품' },
  { value: 'CLOTHING', label: '의류' },
  { value: 'FOOD', label: '식품' },
  { value: 'BOOK', label: '도서' },
  { value: 'HOME', label: '생활용품' }
];

function Home() {
  const navigate = useNavigate();
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [category, setCategory] = useState('');
  const [page, setPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);

  useEffect(() => {
    fetchProducts();
  }, [category, page]);

  const fetchProducts = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await getProducts(page, 20, category || undefined);
      setProducts(data.content);
      setTotalPages(data.totalPages);
    } catch (err) {
      setError('상품을 불러오는데 실패했습니다');
    } finally {
      setLoading(false);
    }
  };

  const handleCategoryChange = (newCategory) => {
    setCategory(newCategory);
    setPage(0);
  };

  const handleProductClick = (productId) => {
    navigate(`/products/${productId}`);
  };

  return (
    <div className="home-container">
      <h1>상품 목록</h1>
      
      {error && <Alert type="error" message={error} onClose={() => setError(null)} />}
      
      <div className="category-tabs">
        {CATEGORIES.map(cat => (
          <button
            key={cat.value}
            className={`category-tab ${category === cat.value ? 'active' : ''}`}
            onClick={() => handleCategoryChange(cat.value)}
          >
            {cat.label}
          </button>
        ))}
      </div>
      
      <ProductList products={products} loading={loading} onProductClick={handleProductClick} />
      
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
    </div>
  );
}

export default Home;
