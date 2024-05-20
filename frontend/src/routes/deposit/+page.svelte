<script>
  // @ts-nocheck
  import Navbar from "$lib/components/Navbar.svelte";
  import { goto } from "$app/navigation";
  import { onMount } from "svelte";

  let username = "";
  let user_id = "";
  let coins = [];
  let amount = 0;
  let current_coin_id = 1;

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

  const deposit = async () => {
    const res = await fetch("http://localhost:3000/api/deposit", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        user_id: parseInt(user_id),
        coin_id: current_coin_id,
        amount: amount,
      }),
    });

    if (res.ok) {
      alert("Deposit successful");
    } else {
      alert("Deposit failed");
    }
  };
</script>

<Navbar
  {username}
  logoutfunction={logout}
/>
<main>
  <h1>Deposit Coins</h1>
  <input
    type="text"
    bind:value={amount}
    placeholder="Amount to deposit"
  />
  <select bind:value={current_coin_id}>
    {#each coins as coin}
      <option value={coin.coin_id}>{coin.coin_name}</option>
    {/each}
  </select>
  <button on:click={deposit}>Deposit</button>
</main>

<style>
  h1 {
    margin: 2rem 2rem 1rem;
  }
  main {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  select {
    padding: 0.5rem;
  }
  button {
    color: white;
    background-color: rgb(83, 83, 83);
    padding: 0.5rem 1rem;
    border: none;
    border-radius: 16px;
    cursor: pointer;
    margin-top: 1rem;
  }
  button:hover {
    background-color: rgb(56, 56, 56);
  }
  button:first-child {
    margin-left: auto;
  }
  input[type="text"] {
    padding: 1rem;
    margin-bottom: 1rem;
    border: none;
    outline: none;
  }

  input[type="text"]:focus {
    border: none;
    outline: none;
  }
</style>
