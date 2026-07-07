import { Routes, Route, Link } from 'react-router-dom'
import Home from './pages/Home'
import Queue from './pages/Queue'
import Seats from './pages/Seats'
import Complete from './pages/Complete'
import Lookup from './pages/Lookup'

export default function App() {
  return (
    <div className="app">
      <header className="topbar">
        <Link to="/" className="logo">🎟️ TICKETING</Link>
        <Link to="/lookup" className="nav-link">예약확인</Link>
      </header>
      <main className="content">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/queue/:concertId" element={<Queue />} />
          <Route path="/seats/:concertId" element={<Seats />} />
          <Route path="/complete" element={<Complete />} />
          <Route path="/lookup" element={<Lookup />} />
        </Routes>
      </main>
    </div>
  )
}
