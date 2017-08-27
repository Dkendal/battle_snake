export function get(href: string): Promise<SVGSVGElement> {
  return new Promise((resolve, reject) => {
    const request = new XMLHttpRequest();

    request.open("GET", href);

    request.addEventListener("load", (event: ProgressEvent) => {
      const request = <XMLHttpRequest>event.currentTarget;

      const xml = request.responseXML;

      if (!xml || !xml.children[0]) {
        return reject('no xml data');
      }

      return resolve(<SVGSVGElement>xml.children[0]);
    });

    request.send();
  });
}

export function svg2image(svg: SVGSVGElement, color: string) {
  svg.setAttribute('fill', color)

  const DOMURL = window.URL || window;

  const image = new Image();

  const blob = new Blob([svg.outerHTML], { type: 'image/svg+xml' });

  const url = DOMURL.createObjectURL(blob);

  image.src = url

  return image
}

export function loadImage(id: string, color: string): Promise<bs.Image> {
  const link = <HTMLLinkElement | null>document.getElementById(id);

  if (!link || !link.href) {
    return Promise.reject('no href on link');
  }

  return get(link.href).then((svg: SVGSVGElement) => {
    return svg2image(svg, color);
  });
}
