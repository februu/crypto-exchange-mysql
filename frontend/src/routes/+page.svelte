<script>
  import { goto } from "$app/navigation";
  import Modal from "$lib/components/Modal.svelte";

  let username = "";
  let password = "";
  let modalTitle = "";
  let modalMessage = "";
  let showModal = false;

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
      sessionStorage.setItem("user_id", data.user_id);
      sessionStorage.setItem("username", data.username);
      goto("/dashboard");
    } else {
      const data = await res.json();
      modalTitle = data.title;
      modalMessage = data.message;
      showModal = true;
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

{#if showModal}
  <Modal
    title={modalTitle}
    message={modalMessage}
    ><button on:click={() => (showModal = false)}>Close</button></Modal
  >
{/if}

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
