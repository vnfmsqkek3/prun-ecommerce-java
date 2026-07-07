import { useEffect, useRef, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import api, { userId } from '../api'

export default function Queue() {
  const { concertId } = useParams()
  const nav = useNavigate()
  const [info, setInfo] = useState(null)
  const tokenRef = useRef(null)
  const timer = useRef(null)

  useEffect(() => {
    let alive = true

    const go = () => {
      // 입장 성공 → 좌석 선택으로. 토큰은 sessionStorage 로 전달
      sessionStorage.setItem(`token:${concertId}`, tokenRef.current)
      nav(`/seats/${concertId}`)
    }

    const poll = async () => {
      try {
        const { data } = await api.get(`/api/queue/${concertId}/status`, { params: { token: tokenRef.current } })
        if (!alive) return
        setInfo(data)
        if (data.status === 'ONGOING') { clearInterval(timer.current); go() }
      } catch { /* keep polling */ }
    }

    // 1) 대기열 입장
    api.post(`/api/queue/${concertId}/enter`, null, { params: { userId: userId() } })
      .then(({ data }) => {
        if (!alive) return
        tokenRef.current = data.token
        setInfo(data)
        if (data.status === 'ONGOING') { go(); return }
        timer.current = setInterval(poll, 2000) // 2초마다 순번 폴링
      })
      .catch(() => setInfo({ status: 'ERROR' }))

    return () => { alive = false; clearInterval(timer.current) }
  }, [concertId, nav])

  return (
    <div className="queue">
      <h1>대기열</h1>
      {!info && <p className="muted">대기열 입장 중…</p>}
      {info?.status === 'WAIT' && (
        <div className="queue-box">
          <div className="big">{info.position}</div>
          <p>내 앞으로 <b>{info.position - 1}</b>명 대기중</p>
          <p className="muted">전체 대기 {info.waitingTotal}명 · 잠시만 기다려 주세요</p>
          <div className="spinner" />
        </div>
      )}
      {info?.status === 'ONGOING' && <p>입장! 좌석 선택으로 이동합니다…</p>}
      {info?.status === 'ERROR' && <p className="err">대기열 입장에 실패했습니다.</p>}
    </div>
  )
}
