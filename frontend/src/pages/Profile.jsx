import { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { updateMe, changePassword } from '../services/userService';
import Input from '../components/common/Input';
import Button from '../components/common/Button';
import Alert from '../components/common/Alert';
import './Profile.css';

function Profile() {
  const { user, updateUser } = useAuth();
  const [formData, setFormData] = useState({ name: '', phoneNumber: '' });
  const [passwordData, setPasswordData] = useState({ currentPassword: '', newPassword: '', newPasswordConfirm: '' });
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (user) {
      setFormData({ name: user.name, phoneNumber: user.phoneNumber || '' });
    }
  }, [user]);

  const handleUpdateProfile = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setMessage(null);
    
    try {
      const updated = await updateMe(formData);
      updateUser(updated);
      setMessage('정보가 수정되었습니다');
    } catch (err) {
      setError(err.response?.data?.message || '정보 수정에 실패했습니다');
    } finally {
      setLoading(false);
    }
  };

  const handleChangePassword = async (e) => {
    e.preventDefault();
    
    if (passwordData.newPassword !== passwordData.newPasswordConfirm) {
      setError('새 비밀번호가 일치하지 않습니다');
      return;
    }
    
    setLoading(true);
    setError(null);
    setMessage(null);
    
    try {
      await changePassword(passwordData.currentPassword, passwordData.newPassword);
      setMessage('비밀번호가 변경되었습니다');
      setPasswordData({ currentPassword: '', newPassword: '', newPasswordConfirm: '' });
    } catch (err) {
      setError(err.response?.data?.message || '비밀번호 변경에 실패했습니다');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="profile-container">
      <h1>내 정보</h1>
      
      {message && <Alert type="success" message={message} onClose={() => setMessage(null)} />}
      {error && <Alert type="error" message={error} onClose={() => setError(null)} />}
      
      <div className="profile-section">
        <h2>기본 정보</h2>
        <form onSubmit={handleUpdateProfile}>
          <Input
            type="email"
            label="이메일"
            value={user?.email || ''}
            disabled
          />
          
          <Input
            type="text"
            label="이름"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            required
          />
          
          <Input
            type="text"
            label="전화번호"
            value={formData.phoneNumber}
            onChange={(e) => setFormData({ ...formData, phoneNumber: e.target.value })}
          />
          
          <Button type="submit" disabled={loading}>저장</Button>
        </form>
      </div>
      
      <div className="profile-section">
        <h2>비밀번호 변경</h2>
        <form onSubmit={handleChangePassword}>
          <Input
            type="password"
            label="현재 비밀번호"
            value={passwordData.currentPassword}
            onChange={(e) => setPasswordData({ ...passwordData, currentPassword: e.target.value })}
            required
          />
          
          <Input
            type="password"
            label="새 비밀번호"
            value={passwordData.newPassword}
            onChange={(e) => setPasswordData({ ...passwordData, newPassword: e.target.value })}
            required
          />
          
          <Input
            type="password"
            label="새 비밀번호 확인"
            value={passwordData.newPasswordConfirm}
            onChange={(e) => setPasswordData({ ...passwordData, newPasswordConfirm: e.target.value })}
            required
          />
          
          <Button type="submit" disabled={loading}>변경</Button>
        </form>
      </div>
    </div>
  );
}

export default Profile;
