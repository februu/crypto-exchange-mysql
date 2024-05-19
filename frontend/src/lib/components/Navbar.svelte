<script>
  export let username = "";
</script>

<nav>
  <ul>
    <li><a href="/dashboard">Home</a></li>
    <li><a href="/assets">Assets</a></li>
    <li class="user-greeting">Welcome back, {username}</li>
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
</style>
