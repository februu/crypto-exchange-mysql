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
        type="text"
        name="fullname"
        id="fullname"
        placeholder="Full Name"
        autocomplete="off"
      />
      <input
        type="text"
        name="username"
        id="username"
        placeholder="Username"
        autocomplete="off"
      />
      <input
        type="text"
        name="email"
        id="email"
        placeholder="E-mail address"
        autocomplete="off"
      />
      <input
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
        type="date"
        name="dob"
        id="dob"
      />
      <input
        type="text"
        name="fulladdress"
        id="fulladress"
        placeholder="Full Address"
        autocomplete="off"
      />

      <button>Create new account</button>
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
