import { Routes, Route, Navigate } from "react-router-dom";
import Inventory from "./Inventory.jsx";
import Login from "./Login.jsx";

function App() {

  const token = localStorage.getItem("token");

  return (
    <Routes>
      <Route
        path="/"
        element={
          token ? <Inventory /> : <Navigate to="/login" replace />
        }
      />

      <Route
        path="/login"
        element={
          token ? <Navigate to="/" replace /> : <Login />
        }
      />
    </Routes>
  );
}

export default App;
