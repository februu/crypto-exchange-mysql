<script>
  // @ts-nocheck
  import Navbar from "$lib/components/Navbar.svelte";
  import OrderModal from "$lib/components/OrderModal.svelte";
  import { goto } from "$app/navigation";
  import { onMount } from "svelte";

  let username = "";
  let user_id = "";
  let coins = [];

  let showOrderModal = false;
  let modal_coin_id = "";
  let modal_coin_symbol = "";
  let modal_coin_name = "";
  let modal_coin_logo_url = "";
  let modal_order_type = "";

  onMount(async () => {
    if (sessionStorage.getItem("user_id") == null) {
      goto("/");
    } else {
      user_id = sessionStorage.getItem("user_id");
      username = sessionStorage.getItem("username");
    }
    const res = await fetch("http://localhost:3000/api/crypto-coins");
    coins = await res.json();
  });

  const logout = () => {
    sessionStorage.removeItem("user_id");
    sessionStorage.removeItem("username");
    goto("/");
  };

  const openOrderModal = (coin, order_type) => {
    console.log(coin);
    showOrderModal = true;
    modal_coin_id = coin.coin_id;
    modal_coin_symbol = coin.coin_symbol;
    modal_coin_name = coin.coin_name;
    modal_coin_logo_url = coin.coin_logo_url;
    modal_order_type = order_type;
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
        <button on:click={() => openOrderModal(coin, "buy")}>Buy</button>
        <button on:click={() => openOrderModal(coin, "sell")}>Sell</button>
      </li>
    {/each}
  </ul>
</main>

{#if showOrderModal}
  <OrderModal
    coin_logo_url={modal_coin_logo_url}
    coin_id={modal_coin_id}
    coin_symbol={modal_coin_symbol}
    coin_name={modal_coin_name}
    order_type={modal_order_type}
    {user_id}
    ><button
      on:click={() => {
        showOrderModal = false;
      }}>Close</button
    ></OrderModal
  >
{/if}

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
