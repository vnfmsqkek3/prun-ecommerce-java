import './Loading.css';

function Loading({ size = 'medium' }) {
  return (
    <div className="loading-container">
      <div className={`spinner spinner-${size}`}></div>
    </div>
  );
}

export default Loading;
