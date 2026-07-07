import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import api from '../api'

export default function Home() {
  const [concerts, setConcerts] = useState([])
  const [loading, setLoading] = useState(true)
  const nav = useNavigate()

  useEffect(() => {
    api.get('/api/concerts')
      .then(r => setConcerts(r.data))
      .catch(() => setConcerts([]))
      .finally(() => setLoading(false))
  }, [])

  if (loading) return <p className="muted">불러오는 중…</p>

  return (
    <>
      <h1>공연 목록</h1>
      <div className="grid">
        {concerts.map(c => (
          <div className="card" key={c.id}>
            <img src={c.imageUrl} alt={c.title} />
            <div className="card-body">
              <h3>{c.title}</h3>
              <p className="muted">{c.artist} · {c.venue}</p>
              <p className="muted">{new Date(c.concertDate).toLocaleString('ko-KR')}</p>
              <button onClick={() => nav(`/queue/${c.id}`)}>예매하기</button>
            </div>
          </div>
        ))}
        {concerts.length === 0 && <p className="muted">공연이 없습니다.</p>}
      </div>
    </>
  )
}
