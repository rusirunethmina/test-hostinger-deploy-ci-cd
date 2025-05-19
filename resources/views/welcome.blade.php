<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Login Form</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
      font-family: 'Segoe UI', sans-serif;
    }

    body {
      background: linear-gradient(to right, #6a11cb, #2575fc);
      height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
    }

    .login-container {
      background-color: white;
      padding: 30px 40px;
      border-radius: 10px;
      box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
      width: 100%;
      max-width: 400px;
    }

    .login-form h2 {
      text-align: center;
      margin-bottom: 20px;
      color: #333;
    }

    .input-group {
      margin-bottom: 15px;
    }

    .input-group label {
      display: block;
      margin-bottom: 6px;
      font-weight: bold;
      color: #333;
    }

    .input-group input {
      width: 100%;
      padding: 10px 12px;
      border: 1px solid #ccc;
      border-radius: 6px;
      transition: border 0.3s;
    }

    .input-group input:focus {
      border-color: #2575fc;
      outline: none;
    }

    button {
      width: 100%;
      padding: 12px;
      background-color: #2575fc;
      color: white;
      border: none;
      border-radius: 6px;
      font-size: 16px;
      cursor: pointer;
      transition: background 0.3s;
    }

    button:hover {
      background-color: #1a5edb;
    }

    .register-link {
      text-align: center;
      margin-top: 15px;
      font-size: 14px;
    }

    .register-link a {
      color: #2575fc;
      text-decoration: none;
    }
  </style>
</head>
<body>
  <div class="login-container">
    <form class="login-form">
      <h2>Login</h2>
      <div class="input-group">
        <label for="email">Email</label>
        <input type="email" id="email" placeholder="Enter your email" required>
      </div>
      <div class="input-group">
        <label for="password">Password</label>
        <input type="password" id="password" placeholder="Enter your password" required>
      </div>
      <button type="submit">Login</button>
      <p class="register-link">Don't have an account? <a href="#">Register</a></p>
    </form>
  </div>
</body>
</html>
