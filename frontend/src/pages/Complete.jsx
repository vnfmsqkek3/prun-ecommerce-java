import { useLocation, useNavigate } from 'react-router-dom'

export default function Complete() {
  const { state } = useLocation()
  const nav = useNavigate()
  const r = state?.reservation

  return (
    <div className="complete">
      <div className="check">✓</div>
      <h1>예약 & 결제 완료!</h1>
      {r ? (
        <div className="ticket">
          <p>예약번호 <b>#{r.id}</b></p>
          <p>공연 <b>{r.concertTitle}</b></p>
          <p>좌석 <b>{r.seatNo}</b> ({r.grade})</p>
          <p>결제 <b>{Number(r.amount).toLocaleString()}원</b> · {r.paymentMethod} · {r.paymentStatus}</p>
          <p className="muted">승인번호 {r.transactionId}</p>
          <p className="kakao">💬 카카오 알림톡으로 예약 확정 안내를 보냈습니다.</p>
        </div>
      ) : <p className="muted">예약 정보가 없습니다.</p>}
      <div className="btn-row">
        <button onClick={() => nav('/lookup')}>예약확인</button>
        <button className="ghost" onClick={() => nav('/')}>목록으로</button>
      </div>
    </div>
  )
}
