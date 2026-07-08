import { useEffect, useRef, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import api, { userId } from '../api'

export default function Queue() {
  const { concertId } = useParams()
  const nav = useNavigate()
  const [info, setInfo] = useState(null)
  const [admitted, setAdmitted] = useState(false)
  const [admitCountdown, setAdmitCountdown] = useState(null) // 입장 후 남은 초
  const tokenRef = useRef(null)
  const enteredRef = useRef(false) // StrictMode 이중 실행에도 입장은 1번만
  const admittedRef = useRef(false) // 입장 완료 여부 (이탈 시 대기표 반납 판단)
  const timerRef = useRef(null)
  const admitTimerRef = useRef(null) // 입장 후 10초 카운트다운 타이머

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
          admittedRef.current = true
          sessionStorage.setItem(`token:${concertId}`, tokenRef.current)
          sessionStorage.setItem(`expiresAt:${concertId}`, data.expiresAt) // 좌석페이지 카운트다운용
          setAdmitted(true)
          // 10초 안에 '입장하기' 미클릭 → 슬롯 반납하고 대기열로 재입장
          let left = 10
          setAdmitCountdown(left)
          clearInterval(admitTimerRef.current)
          admitTimerRef.current = setInterval(() => {
            left -= 1
            if (left <= 0) { clearInterval(admitTimerRef.current); requeue() }
            else setAdmitCountdown(left)
          }, 1000)
        }
      } catch { /* keep polling */ }
    }

    // 입장 후 시간초과 → 활성 슬롯 반납 + 새 대기표로 재입장(맨 뒤로)
    const requeue = async () => {
      const t = tokenRef.current
      if (t) { try { await api.post(`/api/queue/${concertId}/leave`, null, { params: { token: t } }) } catch { /* noop */ } }
      sessionStorage.removeItem(`token:${concertId}`)
      sessionStorage.removeItem(`expiresAt:${concertId}`)
      tokenRef.current = null
      admittedRef.current = false
      enteredRef.current = false
      if (!alive) return
      setAdmitted(false)
      setAdmitCountdown(null)
      setInfo(null)
      await enter()
      timerRef.current = setInterval(poll, 1500)
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
    return () => {
      alive = false
      clearInterval(timerRef.current)
      clearInterval(admitTimerRef.current)
      // 대기 중 페이지 이탈(다른 화면으로 이동) → 대기표 반납해 대기 인원 감소.
      // 입장 완료(admitted)면 좌석페이지로 가는 것이므로 유지. (새로고침/탭닫기는 unmount 안 타서 토큰 보존)
      if (!admittedRef.current && tokenRef.current) {
        navigator.sendBeacon(`/api/queue/${concertId}/leave?token=${tokenRef.current}`)
        sessionStorage.removeItem(`token:${concertId}`)
      }
    }
  }, [concertId])

  const enterNow = () => { clearInterval(admitTimerRef.current); nav(`/seats/${concertId}`) }

  return (
    <div className="queue">
      <h1>대기열</h1>
      {!info && <p className="muted">대기열 입장 중…</p>}

      {admitted ? (
        <div className="queue-box">
          <div className="big">🎉</div>
          <p><b>입장하실 차례입니다!</b></p>
          <p className="muted">아래 버튼을 누르면 좌석 선택으로 이동합니다.</p>
          {admitCountdown != null && (
            <p className={admitCountdown <= 3 ? 'err' : 'muted'}>
              ⏱ <b>{admitCountdown}</b>초 안에 입장하지 않으면 대기열로 돌아갑니다
            </p>
          )}
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
