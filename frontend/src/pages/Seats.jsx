import { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import api, { userId } from '../api'

const METHODS = [
  { v: 'CARD', label: '신용카드' },
  { v: 'KAKAOPAY', label: '카카오페이' },
  { v: 'TOSS', label: '토스' },
]

export default function Seats() {
  const { concertId } = useParams()
  const nav = useNavigate()
  // 입장 토큰은 마운트 시 1번만 캡처 (예약 후 sessionStorage 를 지워도 재-네비게이션 방지)
  const [token] = useState(() => sessionStorage.getItem(`token:${concertId}`))
  const [seats, setSeats] = useState([])
  const [selected, setSelected] = useState(null)
  const [email, setEmail] = useState(localStorage.getItem('email') || '')
  const [phone, setPhone] = useState(localStorage.getItem('phone') || '')
  const [method, setMethod] = useState('CARD')
  const [msg, setMsg] = useState('')
  const [busy, setBusy] = useState(false)
  const [remaining, setRemaining] = useState(null) // 예약 제한시간(초)

  const load = () => api.get(`/api/concerts/${concertId}/seats`).then(r => setSeats(r.data))

  useEffect(() => {
    if (!token) { nav(`/queue/${concertId}`); return } // 토큰 없이 들어오면 대기열로
    load()
    // 예약 제한시간 카운트다운 — 시간 초과 시 슬롯이 서버에서 자동 회수되므로 대기열로 되돌림
    const expiresAt = Number(sessionStorage.getItem(`expiresAt:${concertId}`)) || (Date.now() + 60000)
    const tick = setInterval(() => {
      const sec = Math.ceil((expiresAt - Date.now()) / 1000)
      if (sec <= 0) {
        clearInterval(tick)
        sessionStorage.removeItem(`token:${concertId}`)
        sessionStorage.removeItem(`expiresAt:${concertId}`)
        alert('예약 제한시간이 초과되어 대기열로 돌아갑니다.')
        nav(`/queue/${concertId}`, { replace: true })
      } else {
        setRemaining(sec)
      }
    }, 500)
    return () => clearInterval(tick)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const reserve = async () => {
    if (!selected || !email || !phone) { setMsg('좌석·이메일·전화번호를 입력하세요'); return }
    setBusy(true); setMsg('')
    localStorage.setItem('email', email); localStorage.setItem('phone', phone)
    try {
      const { data } = await api.post('/api/reservations', {
        concertId: Number(concertId), seatId: selected.id, userId: userId(),
        token, email, phone, paymentMethod: method,
      })
      sessionStorage.removeItem(`token:${concertId}`)
      nav('/complete', { state: { reservation: data }, replace: true }) // replace: 뒤로가기로 좌석/대기열 복귀 방지
    } catch (e) {
      setMsg(e.response?.data?.message || '예약/결제에 실패했습니다')
      setSelected(null); load()
      setBusy(false)
    }
  }

  const rows = [...new Set(seats.map(s => s.seatNo[0]))]

  return (
    <div className="seats">
      <h1>좌석 선택 & 결제</h1>
      {remaining != null && (
        <p className={remaining <= 10 ? 'err' : 'muted'}>
          ⏱ 예약 제한시간 <b>{remaining}</b>초 · 시간 초과 시 대기열로 돌아갑니다
        </p>
      )}
      <div className="stage">STAGE</div>
      <div className="seatmap">
        {rows.map(row => (
          <div className="seatrow" key={row}>
            <span className="rowlabel">{row}</span>
            {seats.filter(s => s.seatNo[0] === row).map(s => (
              <button key={s.id}
                className={`seat grade-${s.grade} ${s.status !== 'AVAILABLE' ? 'taken' : ''} ${selected?.id === s.id ? 'sel' : ''}`}
                disabled={s.status !== 'AVAILABLE'}
                onClick={() => setSelected(s)}
                title={`${s.seatNo} · ${s.grade} · ${Number(s.price).toLocaleString()}원`}
              >{s.seatNo.slice(1)}</button>
            ))}
          </div>
        ))}
      </div>
      <div className="legend">
        <span className="dot grade-VIP" /> VIP <span className="dot grade-R" /> R
        <span className="dot grade-S" /> S <span className="dot taken" /> 예약됨
      </div>

      <div className="pay-form">
        <div className="pay-row">
          <label>이메일<input type="email" value={email} placeholder="예약조회용 이메일"
            onChange={e => setEmail(e.target.value)} /></label>
          <label>전화번호<input value={phone} placeholder="카톡 알림톡 (01012345678)"
            onChange={e => setPhone(e.target.value)} /></label>
        </div>
        <div className="pay-row">
          {METHODS.map(m => (
            <button key={m.v} className={`chip ${method === m.v ? 'on' : ''}`}
              onClick={() => setMethod(m.v)}>{m.label}</button>
          ))}
        </div>
      </div>

      {msg && <p className="err">{msg}</p>}
      <div className="reserve-bar">
        {selected
          ? <span>선택: <b>{selected.seatNo}</b> · {selected.grade} · {Number(selected.price).toLocaleString()}원</span>
          : <span className="muted">좌석을 선택하세요</span>}
        <button disabled={!selected || busy} onClick={reserve}>{busy ? '결제 중…' : '결제하고 예약'}</button>
      </div>
    </div>
  )
}
