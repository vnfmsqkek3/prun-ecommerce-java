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
        if (data.status === 'EXPIRED') {
          // 저장된 토큰이 만료됨 → 새로 발급
          sessionStorage.removeItem(`token:${concertId}`)
          tokenRef.current = null
          enteredRef.current = false
          enter()
          return
        }
        setInfo(data)
        if (data.status === 'ONGOING') {
          clearInterval(timerRef.current)
          setAdmitted(true)
        }
      } catch { /* keep polling */ }
    }

    const enter = async () => {
      if (enteredRef.current) return
      enteredRef.current = true
      // 새로고침 시 기존 대기표 재사용 — 매번 새 토큰을 뽑으면 대기열 뒤로 다시 줄서 순번이 계속 밀린다.
      const saved = sessionStorage.getItem(`token:${concertId}`)
      if (saved) {
        tokenRef.current = saved
        poll()
        return
      }
      try {
        const { data } = await api.post(`/api/queue/${concertId}/enter`, null, { params: { userId: userId() } })
        tokenRef.current = data.token
        sessionStorage.setItem(`token:${concertId}`, data.token) // 대기 중에도 즉시 저장(새로고침 대비)
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
