import * as CountryFlags from "country-flag-icons/react/3x2";
import React from "react";

const getCountryName = (countryCode) => {
    return CountryFlags[countryCode ]?.name;
};

export function CountryFlag({
  country,
}) {
  return (
    <>
      {CountryFlags[country]
        ? React.createElement(
            CountryFlags[country],
            {
              title: getCountryName(country),
              className: "w-5",
            }
          )
        : null}
    </>
  );
}
