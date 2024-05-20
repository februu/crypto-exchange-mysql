<script>
  export let username = "";
  export let logoutfunction = () => {};
</script>

<nav>
  <ul>
    <li><a href="/dashboard">Home</a></li>
    <li><a href="/assets">Assets</a></li>
    <li><a href="/deposit">Deposit</a></li>
    <li><a href="/withdraw">Withdraw</a></li>
    <li class="user-greeting">Welcome back, {username}</li>
    <button on:click={logoutfunction}>Logout</button>
  </ul>
</nav>

<style>
  nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem;
    background-color: #333;
    color: #ffffff;
  }

  ul {
    display: flex;
    list-style: none;
    width: 100%;
    margin-left: 1rem;
  }

  li {
    margin-right: 1rem;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .user-greeting {
    margin-left: auto;
  }

  a {
    color: #ffffff;
    text-decoration: none;
  }

  a:hover {
    color: #c0c0c0;
  }
  button {
    color: white;
    background-color: rgb(83, 83, 83);
    padding: 0.5rem 1rem;
    border: none;
    border-radius: 16px;
    cursor: pointer;
  }
  button:hover {
    background-color: rgb(56, 56, 56);
  }
  button:first-child {
    margin-left: auto;
  }
</style>
