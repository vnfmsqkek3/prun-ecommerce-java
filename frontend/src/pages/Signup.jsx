import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { signup } from '../services/userService';
import Input from '../components/common/Input';
import Button from '../components/common/Button';
import Alert from '../components/common/Alert';
import { validateEmail, validatePassword, validatePhoneNumber } from '../utils/validators';
import './Signup.css';

function Signup() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    passwordConfirm: '',
    name: '',
    phoneNumber: ''
  });
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const handleChange = (field) => (e) => {
    setFormData({ ...formData, [field]: e.target.value });
    setErrors({ ...errors, [field]: '' });
  };

  const validate = () => {
    const newErrors = {};
    
    if (!formData.email) {
      newErrors.email = '이메일을 입력하세요';
    } else if (!validateEmail(formData.email)) {
      newErrors.email = '올바른 이메일 형식이 아닙니다';
    }
    
    if (!formData.password) {
      newErrors.password = '비밀번호를 입력하세요';
    } else if (!validatePassword(formData.password)) {
      newErrors.password = '비밀번호는 최소 8자 이상이어야 합니다';
    }
    
    if (formData.password !== formData.passwordConfirm) {
      newErrors.passwordConfirm = '비밀번호가 일치하지 않습니다';
    }
    
    if (!formData.name) {
      newErrors.name = '이름을 입력하세요';
    }
    
    if (formData.phoneNumber && !validatePhoneNumber(formData.phoneNumber)) {
      newErrors.phoneNumber = '올바른 전화번호 형식이 아닙니다';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validate()) return;
    
    setLoading(true);
    setError(null);
    
    try {
      await signup({
        email: formData.email,
        password: formData.password,
        name: formData.name,
        phoneNumber: formData.phoneNumber || undefined
      });
      alert('회원가입이 완료되었습니다');
      navigate('/login');
    } catch (err) {
      const message = err.response?.data?.message || '회원가입에 실패했습니다';
      setError(message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="signup-container">
      <div className="signup-card">
        <h1>회원가입</h1>
        {error && <Alert type="error" message={error} onClose={() => setError(null)} />}
        
        <form onSubmit={handleSubmit}>
          <Input
            type="email"
            label="이메일"
            value={formData.email}
            onChange={handleChange('email')}
            error={errors.email}
            required
          />
          
          <Input
            type="password"
            label="비밀번호"
            value={formData.password}
            onChange={handleChange('password')}
            error={errors.password}
            required
          />
          
          <Input
            type="password"
            label="비밀번호 확인"
            value={formData.passwordConfirm}
            onChange={handleChange('passwordConfirm')}
            error={errors.passwordConfirm}
            required
          />
          
          <Input
            type="text"
            label="이름"
            value={formData.name}
            onChange={handleChange('name')}
            error={errors.name}
            required
          />
          
          <Input
            type="text"
            label="전화번호"
            value={formData.phoneNumber}
            onChange={handleChange('phoneNumber')}
            error={errors.phoneNumber}
            placeholder="010-1234-5678"
          />
          
          <Button type="submit" disabled={loading}>
            {loading ? '처리 중...' : '회원가입'}
          </Button>
        </form>
        
        <p className="signup-footer">
          이미 계정이 있으신가요? <Link to="/login">로그인</Link>
        </p>
      </div>
    </div>
  );
}

export default Signup;
