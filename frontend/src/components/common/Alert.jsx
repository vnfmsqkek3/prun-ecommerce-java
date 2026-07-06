import './Alert.css';

function Alert({ type = 'info', message, onClose }) {
  return (
    <div className={`alert alert-${type}`}>
      <span>{message}</span>
      {onClose && (
        <button className="alert-close" onClick={onClose}>×</button>
      )}
    </div>
  );
}

export default Alert;
