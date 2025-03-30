window.onload = (e) => {
    window.addEventListener('scroll', e => {
        let header = document.querySelector('header')
        if (!header) return
        let stickyPoint = 115;
        let position = window.scrollY

        if (position > stickyPoint) {
            header.classList.add('small')
        } else {
            header.classList.remove('small')
        }
    })

    function scrollToElement(el) {
        if (el) {
            const yOffset = -50; // Adjust this value to account for any fixed headers, etc.
            const y = el.getBoundingClientRect().top + window.scrollY + yOffset;
            window.scrollTo({ top: y, behavior: 'smooth' });
        }
    }

    let scrollLinks = document.querySelectorAll('header.top-header a[href*="#"]');
    scrollLinks?.forEach(link => {
        link.addEventListener('click', e => {
            e.preventDefault();
            let targetId = e.target.getAttribute('href').replace('/#', '');
            let targetElement = document.getElementById(targetId);
            scrollToElement(targetElement)
        })
    });
}
