import { useLocation, useNavigate } from 'react-router-dom'

export default function Complete() {
  const { state } = useLocation()
  const nav = useNavigate()
  const r = state?.reservation

  return (
    <div className="complete">
      <div className="check">✓</div>
      <h1>예약이 완료되었습니다</h1>
      <p className="muted">결제가 정상 처리되었고, 예약 내역을 아래에서 확인하세요.</p>
      {r ? (
        <div className="ticket">
          <div className="ticket-row"><span>예약번호</span><b>#{r.id}</b></div>
          <div className="ticket-row"><span>공연</span><b>{r.concertTitle}</b></div>
          {r.concertDate && <div className="ticket-row"><span>일시</span><b>{new Date(r.concertDate).toLocaleString('ko-KR')}</b></div>}
          <div className="ticket-row"><span>좌석</span><b>{r.seatNo} ({r.grade})</b></div>
          <div className="ticket-row"><span>결제금액</span><b>{Number(r.amount).toLocaleString()}원</b></div>
          <div className="ticket-row"><span>결제수단</span><b>{r.paymentMethod} · {r.paymentStatus}</b></div>
          <div className="ticket-row"><span>승인번호</span><b>{r.transactionId}</b></div>
          <p className="kakao">💬 카카오 알림톡으로 예약 확정 안내를 보냈습니다.</p>
        </div>
      ) : <p className="muted">예약 정보가 없습니다.</p>}
      <div className="btn-row">
        <button onClick={() => nav('/', { replace: true })}>처음으로 돌아가기</button>
        <button className="ghost" onClick={() => nav('/lookup')}>예약확인</button>
      </div>
    </div>
  )
}
