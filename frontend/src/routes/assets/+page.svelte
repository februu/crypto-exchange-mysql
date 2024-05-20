<script>
  // @ts-nocheck
  import Navbar from "$lib/components/Navbar.svelte";
  import { goto } from "$app/navigation";
  import { onMount } from "svelte";

  let username = "";
  let user_id = "";
  let coins = [];

  onMount(async () => {
    if (sessionStorage.getItem("user_id") == null) {
      goto("/");
    } else {
      user_id = sessionStorage.getItem("user_id");
      username = sessionStorage.getItem("username");
    }

    const res = await fetch(
      `http://localhost:3000/api/user/coins-balance/${user_id}`
    );
    coins = await res.json();
  });

  const logout = () => {
    sessionStorage.removeItem("user_id");
    sessionStorage.removeItem("username");
    goto("/");
  };
</script>

<Navbar
  {username}
  logoutfunction={logout}
/>
<main>
  <h1>Coins</h1>
  <ul>
    {#each coins as coin}
      <li>
        <img
          src={coin.coin_logo_url}
          alt=""
        />
        <h3>{coin.coin_symbol}</h3>
        <h3>{coin.coin_name}</h3>
        <h3 class="balance">
          {coin.balance == null ? "0" : coin.balance}
          {coin.coin_symbol}
        </h3>
      </li>
    {/each}
  </ul>
</main>

<style>
  h1 {
    margin: 2rem 2rem 1rem;
  }
  ul {
    list-style: none;
  }
  li {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 1rem 2rem;
  }
  li:hover {
    background-color: rgb(17, 17, 17);
  }
  img {
    width: 2rem;
    height: 2rem;
  }
  .balance {
    margin-left: auto;
    color: rgb(89, 212, 89);
  }
</style>
