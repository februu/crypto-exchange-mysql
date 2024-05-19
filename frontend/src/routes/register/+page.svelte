<script>
  import { goto } from "$app/navigation";
  import Modal from "$lib/components/Modal.svelte";

  let fullname = "";
  let username = "";
  let email = "";
  let password = "";
  let dob = new Date().toJSON().slice(0, 10);
  let fulladdress = "";

  let showModal = false;
  let modalTitle = "";
  let modalmessage = "";

  const register = async () => {
    const res = await fetch("http://localhost:3000/api/register", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        fullname,
        username,
        email,
        password,
        dob,
        fulladdress,
      }),
    });

    const data = await res.json();
    console.log(data);
    modalTitle = data.title;
    modalmessage = data.message;
    showModal = true;
    if (res.ok) {
      setTimeout(() => {
        goto("/");
      }, 3000);
    }
  };
</script>

<main>
  <div class="card">
    <div class="card-header">
      <div>
        <h1>Create new account</h1>
        <p>Please fill out the form below</p>
      </div>
    </div>
    <div class="card-body">
      <input
        bind:value={fullname}
        type="text"
        name="fullname"
        id="fullname"
        placeholder="Full Name"
        autocomplete="off"
      />
      <input
        bind:value={username}
        type="text"
        name="username"
        id="username"
        placeholder="Username"
        autocomplete="off"
      />
      <input
        bind:value={email}
        type="text"
        name="email"
        id="email"
        placeholder="E-mail address"
        autocomplete="off"
      />
      <input
        bind:value={password}
        type="password"
        name="password"
        id="password"
        placeholder="Password"
      />
      <input
        type="password"
        name="password-repeat"
        id="password-repeat"
        placeholder="Repeat password"
        autocomplete="off"
      />
      <input
        bind:value={dob}
        type="date"
        name="dob"
        id="dob"
      />
      <input
        bind:value={fulladdress}
        type="text"
        name="fulladdress"
        id="fulladress"
        placeholder="Full Address"
        autocomplete="off"
      />

      <button on:click={register}>Create new account</button>
    </div>
  </div>

  {#if showModal}
    <Modal
      title={modalTitle}
      message={modalmessage}
      ><button on:click={() => (showModal = false)}>Close</button></Modal
    >
  {/if}
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
    height: fit-content;
  }

  .card-header {
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 2rem 0;
    margin-bottom: 1rem;
    text-align: center;
  }

  h1 {
    font-size: 2rem;
    margin-bottom: 1rem;
  }

  input[type="text"],
  input[type="password"],
  input[type="date"],
  button {
    padding: 1rem;
    width: 100%;
    margin-bottom: 1rem;
    border: none;
    outline: none;
  }

  input[type="text"]:focus,
  input[type="password"]:focus,
  input[type="date"]:focus {
    border: none;
    outline: none;
  }

  button {
    background-color: #387f8b;
    color: #ffffff;
    border-radius: 32px;
    cursor: pointer;
    margin-bottom: 0rem;
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
