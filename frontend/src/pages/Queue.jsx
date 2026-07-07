import { useEffect, useRef, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import api, { userId } from '../api'

export default function Queue() {
  const { concertId } = useParams()
  const nav = useNavigate()
  const [info, setInfo] = useState(null)
  const [admitted, setAdmitted] = useState(false)
  const tokenRef = useRef(null)
  const enteredRef = useRef(false) // StrictMode 이중 실행에도 입장은 1번만
  const timerRef = useRef(null)

  useEffect(() => {
    let alive = true

    const poll = async () => {
      if (!tokenRef.current) return
      try {
        const { data } = await api.get(`/api/queue/${concertId}/status`, { params: { token: tokenRef.current } })
        if (!alive) return
        setInfo(data)
        if (data.status === 'ONGOING') {
          clearInterval(timerRef.current)
          sessionStorage.setItem(`token:${concertId}`, tokenRef.current)
          setAdmitted(true)
        }
      } catch { /* keep polling */ }
    }

    const enter = async () => {
      if (enteredRef.current) return
      enteredRef.current = true
      try {
        const { data } = await api.post(`/api/queue/${concertId}/enter`, null, { params: { userId: userId() } })
        tokenRef.current = data.token
        if (alive) setInfo(data)
      } catch {
        if (alive) setInfo({ status: 'ERROR' })
      }
    }

    enter()
    timerRef.current = setInterval(poll, 1500)
    return () => { alive = false; clearInterval(timerRef.current) }
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
