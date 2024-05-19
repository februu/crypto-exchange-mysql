<script>
  // @ts-nocheck

  import { page } from "$app/stores";
  import Navbar from "$lib/components/Navbar.svelte";
  import { onMount } from "svelte";

  let username = "";
  let coins = [];

  let state;
  page.subscribe((value) => {
    state = value.state;
  });

  if (state) {
    // @ts-ignore
    username = state.username;
  }

  onMount(async () => {
    const res = await fetch("http://localhost:3000/api/crypto-coins");
    coins = await res.json();
    console.log(coins);
  });
</script>

<Navbar {username} />
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
        <button>Buy</button>
        <button>Sell</button>
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
