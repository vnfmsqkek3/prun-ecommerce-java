import { useState } from 'react'
import api from '../api'

export default function Lookup() {
  const [email, setEmail] = useState(localStorage.getItem('email') || '')
  const [list, setList] = useState(null)
  const [busy, setBusy] = useState(false)

  const search = async () => {
    if (!email) return
    setBusy(true)
    try {
      const { data } = await api.get('/api/reservations', { params: { email } })
      setList(data)
    } catch { setList([]) } finally { setBusy(false) }
  }

  return (
    <div className="lookup">
      <h1>예약 확인</h1>
      <p className="muted">예약 시 입력한 이메일로 조회합니다 (로그인 불필요).</p>
      <div className="lookup-form">
        <input type="email" value={email} placeholder="이메일 입력"
          onChange={e => setEmail(e.target.value)}
          onKeyDown={e => e.key === 'Enter' && search()} />
        <button disabled={busy} onClick={search}>{busy ? '조회 중…' : '조회'}</button>
      </div>

      {list && list.length === 0 && <p className="muted">예약 내역이 없습니다.</p>}
      {list && list.length > 0 && (
        <div className="res-list">
          {list.map(r => (
            <div className="res-item" key={r.id}>
              <div className="res-head">
                <b>{r.concertTitle}</b>
                <span className="badge">{r.paymentStatus}</span>
              </div>
              <p className="muted">{r.concertDate && new Date(r.concertDate).toLocaleString('ko-KR')}</p>
              <p>좌석 <b>{r.seatNo}</b> ({r.grade}) · {Number(r.amount).toLocaleString()}원 · {r.paymentMethod}</p>
              <p className="muted">예약 #{r.id} · 승인 {r.transactionId} · {new Date(r.createdAt).toLocaleString('ko-KR')}</p>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
