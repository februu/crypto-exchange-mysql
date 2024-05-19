<script>
  export let title = "";
  export let message = "";
</script>

<div class="overlay"></div>
<div>
  <h2>{title}</h2>
  <p>{message}</p>
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
    background-color: white;
    padding: 1rem;
    border-radius: 0.5rem;
    box-shadow: 0 0 1rem rgba(0, 0, 0, 0.1);
    z-index: 1000;
    color: black;
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
</style>
