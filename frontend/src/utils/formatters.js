export const formatPrice = (price) => {
  return price.toLocaleString('ko-KR') + '원';
};

export const formatDate = (dateString) => {
  const date = new Date(dateString);
  return date.toLocaleDateString('ko-KR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
};

export const getStatusText = (status) => {
  const statusMap = {
    PENDING: '대기중',
    CONFIRMED: '확인됨',
    CANCELLED: '취소됨'
  };
  return statusMap[status] || status;
};

export const getCategoryText = (category) => {
  const categoryMap = {
    ELECTRONICS: '전자제품',
    CLOTHING: '의류',
    FOOD: '식품',
    BOOK: '도서',
    HOME: '생활용품'
  };
  return categoryMap[category] || category;
};
