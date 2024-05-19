<script>
  import { goto } from "$app/navigation";

  let username = "";
  let password = "";

  const login = async () => {
    const res = await fetch("http://localhost:3000/api/login", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        username,
        password,
      }),
    });

    if (res.ok) {
      const data = await res.json();
      goto("/dashboard", { state: { username: data.username } });
    } else {
      console.error("Failed to log in");
    }
  };
</script>

<main>
  <div class="card">
    <div class="card-header">
      <div>
        <h1>Log In</h1>
        <p>or create a new account!</p>
      </div>
    </div>
    <div class="card-body">
      <input
        bind:value={username}
        type="text"
        name="username"
        id="username"
        placeholder="Username"
        autocomplete="off"
      />
      <input
        bind:value={password}
        type="password"
        name="password"
        id="password"
        placeholder="Password"
      />
      <button on:click={login}>Log In</button>
      <p>Don't have an account? <a href="/register">Register here!</a></p>
    </div>
  </div>
</main>

<style>
  main {
    display: flex;
    justify-content: center;
    height: 100vh;
  }

  .card {
    margin: 1rem;
    padding: 1rem;
    background-color: #333;
    color: #ffffff;
    border-radius: 32px;
    width: 30rem;
    height: 70vh;
  }

  .card-header {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 30%;
    margin-bottom: 1rem;
    text-align: center;
  }

  h1 {
    font-size: 2rem;
    margin-bottom: 1rem;
  }

  input[type="text"],
  input[type="password"],
  button {
    padding: 1rem;
    width: 100%;
    margin-bottom: 1rem;
    border: none;
    outline: none;
  }

  input[type="text"]:focus,
  input[type="password"]:focus {
    border: none;
    outline: none;
  }

  button {
    background-color: #387f8b;
    color: #ffffff;
    border-radius: 32px;
    cursor: pointer;
  }

  button:hover {
    background-color: #316d79;
  }

  button:active {
    transform: translateY(1px);
  }

  p {
    margin-top: 1rem;
    text-align: center;
  }
</style>
