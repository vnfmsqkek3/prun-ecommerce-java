import './Input.css';

function Input({ type = 'text', value, onChange, placeholder, error, required = false, label }) {
  return (
    <div className="input-group">
      {label && <label className="input-label">{label}{required && ' *'}</label>}
      <input
        type={type}
        value={value}
        onChange={onChange}
        placeholder={placeholder}
        className={`input ${error ? 'input-error' : ''}`}
        required={required}
      />
      {error && <span className="error-message">{error}</span>}
    </div>
  );
}

export default Input;
