import { useEffect, useRef, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import api, { userId } from '../api'

export default function Queue() {
  const { concertId } = useParams()
  const nav = useNavigate()
  const [info, setInfo] = useState(null)
  const [admitted, setAdmitted] = useState(false)
  const tokenRef = useRef(null)
  const timer = useRef(null)

  useEffect(() => {
    let alive = true

    const onAdmit = () => {
      // 입장 가능 상태 — 자동 이동하지 않고 '입장하기' 버튼을 띄운다
      clearInterval(timer.current)
      sessionStorage.setItem(`token:${concertId}`, tokenRef.current)
      if (alive) setAdmitted(true)
    }

    const poll = async () => {
      try {
        const { data } = await api.get(`/api/queue/${concertId}/status`, { params: { token: tokenRef.current } })
        if (!alive) return
        setInfo(data)
        if (data.status === 'ONGOING') onAdmit()
      } catch { /* keep polling */ }
    }

    api.post(`/api/queue/${concertId}/enter`, null, { params: { userId: userId() } })
      .then(({ data }) => {
        if (!alive) return
        tokenRef.current = data.token
        setInfo(data)
        if (data.status === 'ONGOING') onAdmit()
        else timer.current = setInterval(poll, 2000)
      })
      .catch(() => setInfo({ status: 'ERROR' }))

    return () => { alive = false; clearInterval(timer.current) }
  }, [concertId])

  const enterNow = () => nav(`/seats/${concertId}`)

  return (
    <div className="queue">
      <h1>대기열</h1>
      {!info && <p className="muted">대기열 입장 중…</p>}

      {admitted ? (
        <div className="queue-box">
          <div className="big">🎉</div>
          <p><b>입장하실 차례입니다!</b></p>
          <p className="muted">아래 버튼을 누르면 좌석 선택으로 이동합니다.</p>
          <button onClick={enterNow}>입장하기</button>
        </div>
      ) : info?.status === 'WAIT' ? (
        <div className="queue-box">
          <div className="big">{info.position}</div>
          <p>내 앞으로 <b>{info.position - 1}</b>명 대기중</p>
          <p className="muted">전체 대기 {info.waitingTotal}명 · 잠시만 기다려 주세요</p>
          <div className="spinner" />
        </div>
      ) : info?.status === 'ERROR' ? (
        <p className="err">대기열 입장에 실패했습니다.</p>
      ) : null}
    </div>
  )
}
