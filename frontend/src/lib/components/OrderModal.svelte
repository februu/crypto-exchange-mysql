<script>
  import { onMount } from "svelte";

  export let coin_id = null;
  export let coin_symbol = null;
  export let coin_name = null;
  export let coin_logo_url = null;
  export let user_id = null;
  export let order_type = "buy";

  let lowestSellPrice = 0;

  let price = 0;
  let quantity = 1;
  $: totalPrice = price * quantity;

  onMount(async () => {
    let data = await fetch(
      `http://localhost:3000/api/coin-price/sell/${coin_id}`
    );

    lowestSellPrice = await data.json();
    lowestSellPrice = lowestSellPrice[0][0].lowest_sell_price;
    lowestSellPrice === null
      ? (lowestSellPrice = 0)
      : (lowestSellPrice = lowestSellPrice);
    price = lowestSellPrice;
  });

  const placeOffer = async () => {
    if (quantity <= 0) {
      alert("Quantity must be greater than 0!");
      return;
    }

    let data = await fetch("http://localhost:3000/api/place-order", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        user_id,
        coin_id,
        price,
        quantity,
        order_type,
      }),
    });

    if (data.ok) {
      alert("Order placed successfully!");
    } else {
      alert((await data.json()).message || "An error occurred!");
    }
  };
</script>

<div class="overlay"></div>
<div>
  <img
    src={coin_logo_url}
    alt=""
  />
  {#if order_type === "buy"}
    <h2>Buy {coin_symbol}</h2>
    <p>Buy {coin_name} for PLN.</p>
  {:else if order_type === "sell"}
    <h2>Sell {coin_symbol}</h2>
    <p>Sell {coin_name} for PLN.</p>
  {/if}
  <p class="price">Current price: {lowestSellPrice} PLN</p>
  <input
    type="text"
    bind:value={price}
    placeholder="Price"
  />
  <input
    type="text"
    bind:value={quantity}
    placeholder="Quantity"
  />
  {#if order_type === "buy"}
    <button on:click={placeOffer}
      >Buy {quantity} {coin_symbol} for {totalPrice} PLN</button
    >
  {:else if order_type === "sell"}
    <button on:click={placeOffer}
      >Sell {quantity} {coin_symbol} for {totalPrice} PLN</button
    >
  {/if}

  <slot />
</div>

<style>
  .overlay {
    position: fixed;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
  }
  div {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    background-color: rgb(255, 255, 255);
    padding: 1rem;
    border-radius: 0.5rem;
    box-shadow: 0 0 1rem rgba(0, 0, 0, 0.1);
    z-index: 1000;
    color: black;
    text-align: center;
  }
  img {
    width: 3rem;
    height: 3rem;
    margin-bottom: 1rem;
  }
  h2 {
    font-size: 1.5rem;
    margin-bottom: 0.5rem;
    text-align: center;
  }
  p {
    margin-bottom: 1rem;
    text-align: center;
  }
  .price {
    font-weight: bold;
    color: rgb(89, 212, 89);
  }
  input[type="text"],
  button {
    text-align: center;
    border: 1px solid rgb(158, 158, 158);
    padding: 1rem;
    width: 100%;
    margin-bottom: 1rem;
    outline: none;
  }

  input[type="text"]:focus {
    border: 1px solid rgb(89, 212, 89);
    outline: none;
  }
  button {
    color: white;
    background-color: rgb(92, 165, 77);
    padding: 0.5rem 1rem;
    border: none;
    border-radius: 16px;
    cursor: pointer;
    height: 2rem;
  }
  button:hover {
    background-color: rgb(72, 126, 61);
  }
  button:first-child {
    margin-left: auto;
  }
</style>
